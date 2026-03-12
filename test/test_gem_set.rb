# frozen_string_literal: true

require "test_helper"

class TestGemSet < Minitest::Test
  def test_spaceship_raises_argument_error_for_non_gem_set
    gem_set = Rebundler::GemSet.new(name: "development")
    assert_raises(ArgumentError) { gem_set <=> "not a gem set" }
    assert_raises(ArgumentError) { gem_set <=> 42 }
    assert_raises(ArgumentError) { gem_set <=> nil }
  end

  def test_spaceship_default_sorts_before_named
    default_set = Rebundler::GemSet.new(default: true)
    named_set = Rebundler::GemSet.new(name: "development")

    assert_operator default_set, :<, named_set
  end

  def test_spaceship_named_sets_sort_alphabetically
    alpha = Rebundler::GemSet.new(name: "alpha")
    beta = Rebundler::GemSet.new(name: "beta")

    assert_operator alpha, :<, beta
  end

  def test_spaceship_equal_gem_sets
    a = Rebundler::GemSet.new(name: "development")
    b = Rebundler::GemSet.new(name: "development")

    assert_equal 0, a <=> b
  end

  def test_equality_same_name_and_default
    a = Rebundler::GemSet.new(name: "development", default: false)
    b = Rebundler::GemSet.new(name: "development", default: false)

    assert_equal a, b
  end

  def test_equality_same_name_different_default_are_not_equal
    named = Rebundler::GemSet.new(name: nil, default: false)
    default_set = Rebundler::GemSet.new(name: nil, default: true)

    refute_equal named, default_set
  end

  def test_equality_different_name_is_not_equal
    a = Rebundler::GemSet.new(name: "development")
    b = Rebundler::GemSet.new(name: "test")

    refute_equal a, b
  end

  def test_equality_with_non_gem_set_is_false
    gem_set = Rebundler::GemSet.new(name: "development")

    refute_equal gem_set, "development"
    refute_equal gem_set, nil
  end
end
